HTMLElement = require "HTMLElement"

class Diagram extends HTMLElement
  constructor: ->
    super()
    @addClass "diagram"
    
Diagram::_def = (varname, e)-> eval "#{varname} = e"

core = require "core"

Diagram::_reg_by_ref = (id, obj)->
  exists = (id, diag)-> $("##{id}").length > 0
  ref = core._to_ref id
  throw new Error("Already exists for '#{ref}' in the " + $.kindof(this)) if this[ref]
  throw new Error("Element which has same ID(#{id}) already exists in the document.") if exists id, this
  this[ref] = obj
  ref


core = require "core"
if core.env.is_node
  module.exports = Diagram
else
  core.exports Diagram
