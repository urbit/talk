# `talk`

`talk` is the frontend for `:talk`, the urbit messaging and notifications system.

`talk` is a simple flux app that gets loaded by `tree` as a module.

# Developing

The `desk/` folder in this repo mirrors a desk on an urbit `planet`.  Source files live outside of this folder, we compile them in using watchify / sass and then copy the `/desk` onto the desk we're using for development on a planet.

Our sass depends on bootstrap mixins, so the urbit fork of bootstrap is included as a submodule. 

First:

```
git submodule init
git submodule update --remote
```

Then:

```
npm install
npm run watch
```

## Deploy

Simple:

`cp -r desk/ [$desk_mountpoint]/`

If you have urbit installed in `~/urbit` with a planet called `sampel-sipnym` and have mounted the `home` desk:

`cp -r desk/ ~/urbit/sampel-sipnym/home/`

# Contributing

If you have a patch you'd like to contribute:

- Test your changes using the above instructions
- Fork this repo
- Send us a pull request

# Distribution

Compiled `main.js` and `main.css` get periodically shipped to the [urbit core](http://github.com/urbit/urbit).  Each time these compiled files are moved to urbit core their commit message should contain the sha-1 of the commit from this repo.  
