# [Caelus]

[![CI](https://github.com/rhannequin/caelus/workflows/CI/badge.svg)](https://github.com/rhannequin/caelus/actions?query=workflow%3ACI)

Source code for [caelus.siderealcode.net].

Caelus is an astronomical dashboard built with [Astronoby] and Ruby on Rails. It
displays real-time data about celestial objects, including their positions,
visibility, and other relevant information.

## Philosophy

Caelus was born out of a desire to provide astronomical data in a clear and
concise manner, and most importantly, to open all the data manipulations and
calculations to the public. By leveraging the power of Astronoby, Caelus aims
to make astronomical data accessible and understandable for everyone, from
enthusiasts to professionals.

## Requirements

- Ruby 3.4+
- Rails 8.1+
- SQLite3

## Setup

```
git clone git@github.com:rhannequin/caelus.git
cd caelus
cp .env.example .env
# Edit .env to set your environment variables
bin/setup
```

## Development

Start the development server with:

```
bin/dev
```

## Testing

Caelus uses RSpec for testing. To run the test suite, use the following command:

```
bin/rails spec
```

## Local CI

For a more accurate representation of the CI environment, you can run CI tasks
locally:

```
bin/ci
```

## Production

I should definetely improve these commands, but for now they work.

### Deployment

```
export $(cat .env | xargs) && bin/kamal deploy
```

### Console

```
export $(cat .env | xargs) && bin/kamal console
```

[caelus.siderealcode.net]: https://caelus.siderealcode.net
[Astronoby]: https://github.com/rhannequin/astronoby
