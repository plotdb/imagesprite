require! <[fs fs-extra spritesmith path imagemin imagemin-pngquant ./util]>
pngmin = imagemin-pngquant speed: 1, strip: true, quality: [0.7, 0.8]

build-png = (opt) ->
  new Promise (res, rej) ->
    try
      if !opt.root.endsWith(\/) => opt.root += \/
      if opt.files => files = opt.files.filter(->it)
      else
        files = util.files opt.root, {rule: opt.rule}
          .map -> path.join(it.root, it.path)

      root = (files.0 or {}).root or '.'

      css = [
        """.#{opt.name} {
          display: inline-block;
          position: relative;
        }
        .#{opt.name}:before {
          content: " ";
          width: 100%;
          display: block;
          background-image: url(#{path.join(opt.base, opt.name + '.png')});
        }
        """
      ]

      spritesmith.run src: files, (err, ret) ->
        fs-extra.ensure-dir-sync opt.outdir
        fs.write-file-sync path.join(opt.outdir, opt.name + '.png'), ret.image

        sdim = ret.properties
        [[k,v] for k,v of ret.coordinates].map ([k,v]) ->
          idim = v
          k = k.replace root, ''

          padding-top = "#{idim.height / idim.width * 100}%!important"
          bksize = "#{sdim.width / idim.width * 100}%"
          bkpos-x = "#{(idim.x / sdim.width) * (sdim.width / idim.width) / ((sdim.width / idim.width) - 1) * 100}%"
          bkpos-y = "#{(idim.y / sdim.height) * (sdim.height / idim.height) / ((sdim.height / idim.height) - 1) * 100}%"

          css.push """
          .#{opt.name}[data-name="#k"] {
            width: #{idim.width}px;
          }
          .#{opt.name}[data-name="#k"]:before {
            background-size: #bksize;
            background-position: #bkpos-x #bkpos-y;
            padding-top: #padding-top
          }
          """
        promise = if opt.outdir =>
          fs.write-file-sync path.join(opt.outdir, opt.name + '.css'), css.join('')
          pngmin(ret.image) .then (output) ->
            fs.write-file-sync path.join(opt.outdir, opt.name + '.min.png'), output
        else Promise.resolve!
        promise.then -> res do
          coord: ret.coordinates
          dimension: sdim
    catch e
      return rej e

module.exports = build-png
