require! <[fs ./imagesprite]>

if !process.argv.2 =>
  console.log "usage: imagesprite-svg srcdir [outdir] [name] [base]"
  process.exit -1
imagesprite.svg {
  root: process.argv.2
  outdir: process.argv.3 or '.'
  name: process.argv.4 or 'svg-sprite'
  base: process.argv.5 or '/'
}
  .then -> console.log "done."
