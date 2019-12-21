require! <[fs ./imagesprite spritesmith path]>

if !process.argv.2 =>
  console.log "usage: imagesprite-png srcdir [outdir] [name] [base]"
  process.exit -1

opt = {
  root: process.argv.2
  outdir: process.argv.3 or '.'
  name: process.argv.4 or 'png-sprite'
  base: process.argv.5 or '/'
}

files = imagesprite.files opt.root, {rule: /\.png$/}
  .map ->
    console.log ">", it
    path.join(it.root, it.path)
console.log files
root = (files.0 or {}).root or '.'

css = [
  """.sprite {
    display: inline-block;
    position: relative;
  }
  .sprite:before {
    content: " ";
    width: 100%;
    display: block;
    background-image: url(#{path.join(opt.base, opt.name + '.png')});
  }
  """
]

spritesmith.run src: files, (err, ret) ->
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
    .sprite[data-name="#k"] {
      width: #{idim.width}px;
    }
    .sprite[data-name="#k"]:before {
      background-size: #bksize;
      background-position: #bkpos-x #bkpos-y;
      padding-top: #padding-top
    }
    """
  fs.write-file-sync path.join(opt.outdir, opt.name + '.css'), css.join('')
  console.log "done."

