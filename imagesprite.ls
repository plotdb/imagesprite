require! <[fs path jsdom svgo]>
svgo = new svgo {full: true, plugins: [ { minifyStyles: {} } ]}
jsdom = jsdom.JSDOM

get-dim = (svg) ->
  document = (new jsdom(svg)).window.document
  svg = document.querySelector 'svg'
  viewBox = (svg.getAttribute(\viewBox) or '0 0 100 100').split(' ')
  width = +("#{svg.style.width or svg.getAttribute(\width) or viewBox.2}".replace(/[^0-9]+$/,''))
  height = +("#{svg.style.height or svg.getAttribute(\height) or viewBox.3}".replace(/[^0-9]+$/,''))
  return {width, height}

recurse = (root, config = {}, list = [], relpath = '.') ->
  if !fs.stat-sync(path.join(root, relpath)).is-directory! =>
    if !config.rule.exec(relpath) => return
    list.push {root, path: relpath}
    return
  files = fs.readdir-sync path.join(root, relpath) .map -> path.join relpath, it
  for file in files => recurse root, config, list, file

files = (root, config) ->
  recurse root, config, list = []
  return list

handle-svg = (list) ->
  promise = new Promise (res, rej) ->
    sdim = {width: 0, height: 0}
    code = []
    coordinates = []
    _ = (list) ->
      file = list.splice(0,1).0
      if !file => return res {sdim, code, coordinates}
      data = fs.read-file-sync(path.join(file.root, file.path)).toString!
      svgo.optimize(data)
        .then ->
          {width, height} = get-dim(it.data)
          [x,y] = [sdim.width, 0]
          if height > sdim.height => sdim.height = height
          ret = Buffer.from(it.data).toString('base64')
          code.push """<image x="#{x}" y="#{y}" width="#width" height="#height" xlink:href="data:image/svg+xml;base64,#ret"/>"""
          coordinates[file.path] = {x, y, width, height}
          sdim.width += width
          _ list
    _ list

build-svg = (opt = {}) ->
  name = opt.name or 'svg-sprite'
  outdir = opt.outdir
  base = opt.base
  recurse opt.root, {rule: /\.svg$/}, (list=[])
  handle-svg list
    .then ({sdim, code, coordinates}) ->
      ret = {}
      ret.image = """
      <?xml version="1.0" encoding="utf-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      #{code.join('\n')}
      </svg>
      """
      bkimg = if base and name => "background-image: url(#{path.join(base, name + '.svg')});" else ""
      css = [
        """.#name {
          display: inline-block;
          position: relative;
        }
        .#name:before {
          content: " ";
          width: 100%;
          display: block;
          #bkimg
        }
        """
      ]
      for k,idim of coordinates =>
        padding-top = "#{idim.height / idim.width * 100}%!important"
        bksize = "#{sdim.width / idim.width * 100}%"
        bkpos-x = "#{(idim.x / sdim.width) * (sdim.width / idim.width) / ((sdim.width / idim.width) - 1) * 100}%"
        bkpos-y = "#{(idim.y / sdim.height) * (sdim.height / idim.height) / ((sdim.height / idim.height) - 1) * 100}%"
        css.push """
        .#name[data-src="#k"] {
          width: #{idim.width}px;
        }
        .#name[data-src="#k"]:before {
          background-size: #bksize;
          background-position: #bkpos-x #bkpos-y;
          padding-top: #padding-top
        }
        """
      ret.css = css.join(\\n)
      ret.coord = coordinates
      ret.dimension = sdim
      if outdir =>
        fs.write-file-sync path.join(outdir, "#name.svg"), ret.image
        fs.write-file-sync path.join(outdir, "#name.css"), ret.css
      return ret

module.exports = {svg: build-svg, files: files}
