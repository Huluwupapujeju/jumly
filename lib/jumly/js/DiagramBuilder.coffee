JUMLY = window.JUMLY

class DiagramBuilder
  @selectHTMLScriptElements = (e)->
    $("script", e).not(".ignored")

DiagramBuilder::beforeCompose = (f)->
  @diagram.bind "beforeCompose", f
  this

DiagramBuilder::afterCompose = (f)->
  @diagram.bind "afterCompose", f
  this

DiagramBuilder::before = -> @beforeCompose.apply this, arguments

DiagramBuilder::after = -> @afterCompose.apply this, arguments

DiagramBuilder::accept = (f)-> f.apply this, []

DiagramBuilder::build = (jumlipt)->
  try
    typename = this.constructor.name.replace(/^JUMLY/, "")
                                    .replace(/Diagram(Builder)?$/, "")
                                    .toLowerCase()
    @diagram = $.jumly ".#{typename}-diagram"
    @accept -> eval CoffeeScript.compile jumlipt
    @diagram.trigger "build.after"
    @diagram
  catch ex
    console.error ex.stack, jumlipt
    throw new JUMLY.Error "failed_to_build", "Failed to build", [], ex, jumlipt

DiagramBuilder::note = (text)->
  $.jumly(".note").find(".content").html(text).end().appendTo @diagram

JUMLY.DiagramBuilder = DiagramBuilder


