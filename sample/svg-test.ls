require! <[fs ./src]>

if !process.argv.2 =>
  console.log "usage: imagesprite-svg srcdir [outdir] [name] [base] [file]"
  process.exit -1
src.svg {
  root: process.argv.2
  outdir: process.argv.3 or '.'
  name: process.argv.4 or 'svg-sprite'
  base: process.argv.5 or '/'
  files: (fs.read-file-sync 'svg.list' .toString!).split(\\n)
}
  .then -> console.log "done."
