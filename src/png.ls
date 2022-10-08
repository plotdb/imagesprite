require! <[fs fs-extra spritesmith path imagemin-pngquant uglifycss ./util]>
pngmin = imagemin-pngquant speed: 1, strip: true, quality: [0.7, 0.8]

build-png = (opt) ->
  new Promise (res, rej) ->
    try
      if opt.root.endsWith(\/) => opt.root.replace(/\/$/,'')
      if opt.files => files = opt.files.filter(->it)
      else
        files = util.files opt.root, {rule: opt.rule}
          .map -> path.join(it.root, it.path)

      root = opt.root or '.'

      spritesmith.run src: files, (err, ret) ->
        fs-extra.ensure-dir-sync opt.outdir
        fs.write-file-sync path.join(opt.outdir, opt.fname + '.png'), ret.image

        sdim = ret.properties
        list = [[k,v] for k,v of ret.coordinates].map ([k,idim]) ->
          name = k.replace(root, '').replace(/^\//, '').replace(/\.png$/,'')
          if opt.prefix => name = path.join opt.prefix, name
          padding-top = "#{idim.height / idim.width * 100}%!important"
          bksize = "#{sdim.width / idim.width * 100}%"
          bkpos =
            x: "#{(idim.x / sdim.width) * (sdim.width / idim.width) / ((sdim.width / idim.width) - 1) * 100}%"
            y: "#{(idim.y / sdim.height) * (sdim.height / idim.height) / (((sdim.height / idim.height) - 1) or 1) * 100}%"
          return {width: idim.width, name, padding-top, bksize, bkpos}
        same = {}
        <[width paddingTop bksize]>.map (n) ->
          if (ret = Array.from(new Set(list.map -> it[n]))).length => same[n] = ret.0

        css = [
          """.#{opt.cname} {
            display: inline-block;
            position: relative;
            #{if same.width => "width: #{same.width}px" else ''}
          }
          .#{opt.cname}:before {
            content: " ";
            width: 100%;
            display: block;
            background-image: url(#{path.join(opt.base, opt.fname + '.min.png')});
            #{if same.padding-top => "padding-top: #{same.padding-top};" else ''}
            #{if same.bksize => "background-size: #{same.bksize};" else ''}
          }
          """
        ]

        list.map ({name, width, padding-top, bksize, bkpos}) ->
          if !same.width => css.push ".#{opt.cname}[n=#name] { width: #{width}px; }"
          styles =
            bksize: "background-size: #bksize;"
            bkpos: "background-position: #{bkpos.x} #{bkpos.y};"
            padding-top: "padding-top: #padding-top"
          styles = [{k,v} for k,v of styles].filter(->!(same[it.k]?)).map(->it.v)
          css.push """.#{opt.cname}[n=#name]:before {
            #styles
          }"""

        css = css.join('')
        css-min = uglifycss.processString(css, uglyComments: true)

        promise = if opt.outdir =>
          fs.write-file-sync path.join(opt.outdir, opt.fname + '.css'), css
          fs.write-file-sync path.join(opt.outdir, opt.fname + '.min.css'), css-min
          pngmin(ret.image) .then (output) ->
            fs.write-file-sync path.join(opt.outdir, opt.fname + '.min.png'), output
        else Promise.resolve!
        promise.then -> res do
          coord: ret.coordinates
          dimension: sdim
    catch e
      return rej e

module.exports = build-png
