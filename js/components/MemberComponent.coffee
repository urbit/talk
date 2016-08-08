Ship = window.tree.util.components.ship
recl = React.createClass
rele   = React.createElement
{div,input,textarea} = React.DOM

module.exports = recl
  displayName:"Member"
  render: ->
    ship = @props.ship ? ""

    k = "ship"
    k+= " #{@props.presence}" if @props.presence
    div {className:"iden",key:"iden"}, [
      (rele Ship, {ship})
    ]
