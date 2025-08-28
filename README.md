# Carrier scans

## Prerequisites

To run the application locally, you'll have to follow the following steps:

```shell
$ bundle
$ cp .env.sample .env
$ bin/rails db:create db:migrate db:test:prepare
```

After you've done this, please change the environment variables in the `.env` to something else. You can use any arbitrary value (hint: use `bin/rails secret` to generate secrets).

## The Context

This Ruby on Rails application is responsible for receiving tracking events from a carrier one of our merchants is using. The goal of the application is to transform the carrier status to a status message for [Fulfil](https://www.fulfil.io) (the ERP the merchant is using).

The process works like this:
- the `POST /tracking_events` endpoint is used to receive these tracking events.
  - any tracking status **we can map one-to-one** (between the carrier's definition and Fulfil's definition), is automatically converted.
  - any tracking status **we can't directly map**, is pushed to a background job for further analysis (see `TrackingEvents::StatusDetectionJob`).
- after a tracking status is normalized or detected, the tracking event is pushed to Fulfil.

## The Problem

Currently, we're not properly able to detect the "first delivery attempt" tracking events, while we did write the code for it.

It turns out that the carrier's documentation wasn't accurate. We expected the "first delivery attempt" tracking events to have a "DATA ONLY" status. However, they were shared to us with an "IN TRANSIT" status. Because we can directly map the "IN TRANSIT" carrier status to the "in_transit" carrier status in Fulfil, we never even tried to see if it's actually an "first delivery attempt".

## The Goal

Find a way to detect the "first delivery attempt" tracking events, and ensure they're pushed to Fulfil with a status of "failure". After you've found a way of doing this, create tests, create a PR in this repository, and document your solution in the PR. In a video call, we'll go over your solution and you're able to explain and answer any questions.

## Rabbit holes / callouts

- Don't use AI to generate a solution to the problem. It's a direct reason for us to not work with you. Solve the problem on your own. We're hiring you, not an AI.
- How Fulfil.io works is irrelevant for solving this problem.
- You can't introduce any new Ruby gems to solve the problem.
- You need to write tests that prove your solution works.
- In case of questions, e-mail at [stefan@codeture.nl](mailto:stefan@codeture.nl)
- You have an hour to complete this test. When you're not done after an hour, stop, create a PR with what you have. It's more important to see what you're able to come up with in an hour than to find the final solution to the problem.
