# Implementation Notes

## 1.  Installation

### Prerequsites

It may be necessary to install redis if not already present.

### Setup

Setup will look something like:

```
./bin/bundle update

./bin/rails db:migrate

./bin/bundle exec sidekiq

./bin/bundle exec rails recs:get_all
```

### Maintenenace

The rake task at the end may also be invoked by cron or some other OS scheduling facility.

Something like:

```
export RAILS_PATH=<project path>
( crontab -l 2>/dev/null; echo "* 1 * * * ( cd \"${RAILS_PATH}\"; ./bin/bundle exec rails recs:get_all >> ./log/cron.log 2>&1 )" ) | crontab -
```

is probably suitable.


## 2.  Testing


### Backend

Tests are back-end focused, and can be run with

`./bin/bundle exec rspec`

### Frontend

#### Parameterized URL fornm

The API can be tested by running the rails server and browsing to

http://localhost:3000/users/1/cars/recommended.json

or similar url, with any combination of url parameters such as

http://localhost:3000/users/1/cars/recommended.json?page_size=40

#### Request body fornm

It should also work with a POST or QUERY containing parameters in JSON format.


## 3.  Implementation of spec

I have interpreted the specifications in a couple of ways.

- The absence of a user preferred price range means that all cars count as "in range" in terms of preferred price.  Thus for users with no preferred price range, there are only two labels:  best_match and null.  There will be no good_match entries in that case.  That is expected behavior.

- Maintenance of price ranking is completely asynchronous with respect to recommendation requests.  Thus a maintenance strategy is required by the system operator and is not included explicitly as part of the rails app.  See installation notes for one way to handle this.  For testing and evaluation purposes, running the maintenance rake script should suffice.

- There are two resources for accessing the car recommendations.  They are implemented identically, it is just two different resource paths.

GET http://localhost:3000/users/1/cars/recommended.json  # expected for use with url parameters
POST | QUERY http://localhost:3000/user_car_recommendations.json  # expected for use with POST or QUERY request body


## 4.  Architecture

### Approach

My perception of the core problem presented by the requirements is that it is a data partitioning problem.  So my solution takes that form.  I implement a weighting query in pure SQL since Rails does not make it easy or maintainable to do idiomatically.    This query pulls together a complete view of the cars relation, blocked into 3 groups:  cars that match a user's preferred brands and are not outside any preferred price range; cars that match preferred brands but are outside preferred price range; and all others.  These groups are assigned a numeric label which is used to order them.  When serialized, the numeric label is converted into "best_match," "good_match," or null, respectively.  The serialized output is then displayed as JSON to the user.

The weighting query uses left joining to group and so should be fairly scalable.  I particularly avoided case statements and multiple queries since they quickly become unperformant at scale.  Conversely I did want to make sure that I could make the best possible use union, left join, and paging parameters to pass workload optimization hints to the query planner as early as possible.

### Performance

I have not done serious stress-testing on this solution but based on my evaluation of query planning I believe it will scale predictably.  Ultimately the return set of any request is O(N) over all cars so the size of the cars table will always matter.  But the impact can be minimized by aggressively bounding the problem, and by structuring the query in such a way that the planner can pass those bounds down and optimize effectively with them.

---



---

# Introduction

We want to build a car market platform and provide a personalized selection of cars to our users. There are few main models:

* `Brand(name)` - car brands like Mercedes-Benz, Toyota, Volkswagen, BMW.
* `Car(model_name, brand_id, price)` -  cars for sale.
* `User(email, preferred_price_range)` - our users who want to buy a car.
* `UserPreferredBrand(user_id, brand_id)` - relationship to connect the user and his preferred car brands.

We already prepared rails models and seeds data that you can use but feel free to make any changes here (including model relations, validations, database changes etc).

We also have an external recommendation service with modern AI algorithms. The service provides recommended cars for the user. There is the API endpoint `https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id=<USER_ID>` with the following response schema:

```
[
  {
    car_id: <car id>, # car id from seeds data
    rank_score: <number between 0..1> # the higher, then the car the more relevant to the user
  },
  ...
]
```

The response will contain only the top 10 recommended cars for the user. Like many modern AI algorithms, our service not always work well and sometimes can be unavailable or respond with errors. Also, it's not a real-time solution and has updated data only one time every day.

# Assignment


You need to build API endpoint that will accept the following parameters:

```
{
  "user_id": <user id (required)>
  "query": <car brand name or part of car brand name to filter by (optional)>
  "price_min": <minimum price (optional)>
  "price_max": <maximum price (optional)>
  "page": <page number for pagination (optional, default 1, default page size is 20)>
}
```

The API endpoint should return paginated cars list filtered by params passed with the following rules:

1. Each car should have one of the label:
   * `perfect_match` - cars matched with user preferred car brands ( `user.preferred_brands.include?(car.brand) == true`) and with preferred price (`user.preferred_price_range.include?(car.price) == true`).
   * `good_match` - cars matched only user preferred car brands (`user.preferred_brands.include?(car.brand) == true`).
   * `null` - in other cases
2. Each car should have the `rank_score` field with value from AI service or `null` if there is no data.
3. Cars should be sorted by:
   * `label` (`perfect_match`, `good_match`, `null`)
   * `rank_score` (DESC)
   * `price` (ASC)

Schema of response:
```
[
  {
    "id": <car id>
    "brand": {
      id: <car brand id>,
      name: <car brand name>
    },
    "price": <car price>,
    "rank_score": <rank score>,
    "model": <car model>,
    "label": <perfect_match|good_match|nil>
  },
  ...
]
```

# Example of response

Suppose that the user has preferred brands as `Alfa Romeo` and `Volkswagen` and preferred price `35_000...40_000`. The external recommendation service return for this user following data:
```
[
  { "car_id": 179, "rank_score": 0.945 },
  { "car_id": 5,   "rank_score": 0.4552 },
  { "car_id": 13,  "rank_score": 0.567 },
  { "car_id": 97,  "rank_score": 0.9489 },
  { "car_id": 32,  "rank_score": 0.0967 },
  { "car_id": 176, "rank_score": 0.0353 },
  { "car_id": 177, "rank_score": 0.1657 },
  { "car_id": 36,  "rank_score": 0.7068 },
  { "car_id": 103, "rank_score": 0.4729 }
]
```
Then based on seeds data if you request the API with the following params:
```
{
  "user_id": 1,
  "page": 1
}
```
the response from API should be:
```
[
  {
    "id": 179,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "Derby",
    "price": 37230,
    "rank_score": 0.945,
    "label": "perfect_match"
  },
  {
    "id": 5,
    "brand": {
      "id": 2,
      "name": "Alfa Romeo"
    },
    "model": "Arna",
    "price": 39938,
    "rank_score": 0.4552,
    "label": "perfect_match"
  },
  {
    "id": 180,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "e-Golf",
    "price": 35131,
    "rank_score": null,
    "label": "perfect_match"
  },
  {
    "id": 181,
    "brand": {
      "id": 39,
      "name": "Volkswagen"
    },
    "model": "Amarok",
    "price": 31743,
    "rank_score": null,
    "label": "good_match"
  },
  {
    "id": 186,
    "brand": {
      "id": 2,
      "name": "Alfa Romeo"
    },
    "model": "Brera",
    "price": 40938,
    "rank_score": null,
    "label": "good_match"
  },
  {
    "id": 97,
    "brand": {
      "id": 20,
      "name": "Lexus"
    },
    "model": "IS 220",
    "price": 39858,
    "rank_score": 0.9489,
    "label": null
  },
  {
    "id": 36,
    "brand": {
      "id": 6,
      "name": "Buick"
    },
    "model": "GL 8",
    "price": 86657,
    "rank_score": 0.7068,
    "label": null
  },
  {
    "id": 13,
    "brand": {
      "id": 3,
      "name": "Audi"
    },
    "model": "90",
    "price": 56959,
    "rank_score": 0.567,
    "label": null
  },
  {
    "id": 103,
    "brand": {
      "id": 22,
      "name": "Lotus"
    },
    "model": "Eclat",
    "price": 48953,
    "rank_score": 0.4729,
    "label": null
  },
  {
    "id": 177,
    "brand": {
      "id": 38,
      "name": "Toyota"
    },
    "model": "Allion",
    "price": 40687,
    "rank_score": 0.1657,
    "label": null
  },
  {
    "id": 32,
    "brand": {
      "id": 6,
      "name": "Buick"
    },
    "model": "Verano",
    "price": 21739,
    "rank_score": 0.0967,
    "label": null
  },
  {
    "id": 176,
    "brand": {
      "id": 37,
      "name": "Suzuki"
    },
    "model": "Kizashi",
    "price": 40181,
    "rank_score": 0.0353,
    "label": null
  },
  {
    "id": 113,
    "brand": {
      "id": 24,
      "name": "Mazda"
    },
    "model": "3",
    "price": 1542,
    "rank_score": null,
    "label": null
  },
  {
    "id": 100,
    "brand": {
      "id": 20,
      "name": "Lexus"
    },
    "model": "RX 300",
    "price": 1972,
    "rank_score": null,
    "label": null
  },
  {
    "id": 184,
    "brand": {
      "id": 40,
      "name": "Volvo"
    },
    "model": "610",
    "price": 3560,
    "rank_score": null,
    "label": null
  },
  {
    "id": 142,
    "brand": {
      "id": 31,
      "name": "Ram"
    },
    "model": "Promaster City",
    "price": 3687,
    "rank_score": null,
    "label": null
  },
  {
    "id": 120,
    "brand": {
      "id": 26,
      "name": "Mercury"
    },
    "model": "Marauder",
    "price": 3990,
    "rank_score": null,
    "label": null
  },
  {
    "id": 109,
    "brand": {
      "id": 23,
      "name": "Maserati"
    },
    "model": "Levante",
    "price": 4243,
    "rank_score": null,
    "label": null
  },
  {
    "id": 89,
    "brand": {
      "id": 16,
      "name": "Infiniti"
    },
    "model": "M25",
    "price": 4372,
    "rank_score": null,
    "label": null
  },
  {
    "id": 164,
    "brand": {
      "id": 35,
      "name": "Smart"
    },
    "model": "Forfour",
    "price": 4391,
    "rank_score": null,
    "label": null
  }
]
```

If you add `"query": "Volks"` parameter to the request then only cars with a brand name that includes `Volks` should be in the response. The same logic for `price_min` and `price_max`.

# Criteria for evaluation

* API endpoint should work fast with growing data in DB
* The code should be decomposed to make changes easily
* Test coverage to be sure that everything works well

# Notes

You can use any gems and make any changes in the repo.

# Attention

Please don't open any PRs in this repository. The best way is just to send an archive with your code to us.
