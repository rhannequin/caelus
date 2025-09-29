# [Caelus]

[![CI](https://github.com/rhannequin/caelus/workflows/CI/badge.svg)](https://github.com/rhannequin/caelus/actions?query=workflow%3ACI)

Source code for [caelus.siderealcode.net].

## Deployment

```
export $(cat .env | xargs) && bin/kamal deploy
```

## Console

```
export $(cat .env | xargs) && bin/kamal console
```

[caelus.siderealcode.net]: https://caelus.siderealcode.net
