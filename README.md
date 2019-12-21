# imagesprite

SVG / PNG sprite generator.

## usage

```
    imagesprite.svg(config).then(ret) -> ...
```

config:

 * root: image directory
 * outdir: dir for generating sprite image and css
 * name: generated file name
 * base: relative path for accessing the sprite image via web.

example:

```
    imagesprite.svg({
      root: 'static/assets/img',
      outdir: 'static/assets/sprite'
      name: 'svg-sprite',
      base: '/assets/sprite'
    })
```

## License

MIT.
