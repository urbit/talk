# `talk`

`talk` is the frontend for `:talk`, the urbit messaging and notifications system.

`talk` is a simple flux app that gets loaded by `tree` as a module.

# Developing

## JavaScript

In `js/`:

```
npm install
watchify -v -t coffeeify -o main.js main.coffee
```

## CSS

Our sass depends on bootstrap mixins, so the urbit fork of bootstrap is included as a submodule. 

First:

`git submodule init`
`git submodule update --remote`

Then, in `css/`:

`sass --watch main.scss:main.css`
