require! <[fs]>
imagesprite = require "../index"

if !process.argv.2 =>
  console.log "usage: imagesprite-png srcdir [outdir] [name] [base] [rule]"
  process.exit -1
imagesprite.png {
  root: process.argv.2
  outdir: process.argv.3 or '.'
  fname: process.argv.4 or 'png-sprite'
  cname: process.argv.5 or 'png-sprite'
  base: process.argv.6 or '/'
  rule: if process.argv.7 => new RegExp(process.argv.7) else /\.png$/
}
  .then -> console.log "done."

