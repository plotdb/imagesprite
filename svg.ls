require! <[fs ./src]>

if !process.argv.2 =>
  console.log "usage: imagesprite-svg srcdir [outdir] [name] [base] [rule]"
  process.exit -1
src.svg {
  root: process.argv.2
  outdir: process.argv.3 or '.'
  name: process.argv.4 or 'svg-sprite'
  base: process.argv.5 or '/'
  rule: if process.argv.6 => new RegExp(process.argv.6) else /\.svg$/
}
  .then -> console.log "done."
