fs = require "fs"
child_process = require "child_process"
temp = require 'temp'

module.exports = (ctx)->
  b64decode: (req, res)->
    b64 = req.body.data.replace /^data:image\/png;base64,/, ""
    buf = new Buffer(b64, 'base64').toString 'binary'
    res.contentType "image/png"
    res.header "Content-Disposition", "attachment; filename=" + "diagram.png"
    res.status 201
    res.end buf, "binary"

  diagrams: (req, res)->
    temp.open "jumly", (err, info)->
      throw err if err
      console.log info, req.text
      fs.write info.fd, req.text
      fs.close info.fd, (err)->
        throw err if err

        format = req.query.format or "png"
        encoding = req.query.encoding or "base64"

        filepath = ""
        if encoding.match /image/  ## jumly.sh prints the filepath to stdout
          stdouth = (data)-> filepath += data
        else
          stdouth = (data)-> res.write data

        title = child_process.spawn "#{__dirname}/../bin/jumly.sh", [info.path, format, encoding]
        title.stdout.on 'data', stdouth
        title.stderr.on 'data', (data)-> res.write data

        unlink = (path)->
          fs.unlink path, (err)->
            if err
              console.err "unlink: #{err}"
            else
              console.log "unlink: #{path}"

        title.on 'close', (code)->
          if filepath
            fs.readFile filepath.trim(), flags:"rb", (err, data)->
              throw err if err
              res.write data
              res.end()
              unlink info.path
              unlink filepath.trim()
          else
            res.end()
            unlink info.path