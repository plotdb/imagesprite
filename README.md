# imagesprite

SVG / PNG sprite generator.


## usage

install imagesprite:

    npm install @plotdb/imagesprite


command line usage:

    
    npx imagesprite-png srcdir [outdir] [name] [webbase]
    npx imagesprite-svg srcdir [outdir] [name] [webbase]


Following is the example in `npm run test-build` from our `package.json`:

    npx imagesprite-png test/pngs web/static/assets/img/pack/png png-sprite /assets/img/pack/png
    npx imagesprite-svg test/svgs web/static/assets/img/pack/svg svg-sprite /assets/img/pack/svg


Use with nodejs:

    imagesprite = require("@plotdb/imagesprite");
    imagesprite.svg(config).then(ret) -> ...


config:

 - `srcdir`: image directory
 - `outdir`: dir for generating sprite image and css
 - `name`: generated file name and css class name
 - `base`: relative path for accessing the sprite image via web.


example:

    imagesprite.svg({
      root: 'static/assets/img',
      outdir: 'static/assets/sprite'
      name: 'svg-sprite',
      base: '/assets/sprite'
    })


## License

MIT.
