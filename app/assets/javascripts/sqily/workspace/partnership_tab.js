Sqily.Workspace.PartnershipTab = function(element) {
  Barber.listenEvents(this.root = element, this)
}

Sqily.Workspace.PartnershipTab.prototype.suggestUser = function(event) {
  this.initializeTribute(event.currentTarget)
}

Sqily.Workspace.PartnershipTab.prototype.initializeTribute = function(element) {
  if (this.tribute)
    return
  this.tribute = new Tribute({
    menuContainer: document.getElementById('workspace-partnerships-tab'),
    lookup: "name",
    fillAttr: "name",
    values: this.loadUserList(element)
  })
  this.tribute.attach(element)
  this.tribute.showMenuForCollection(element)
}

Sqily.Workspace.PartnershipTab.prototype.loadUserList = function(element) {
  return JSON.parse(element.getAttribute("data-user-list"))
}

Sqily.Workspace.PartnershipTab.prototype.userSelected = function(event) {
  this.root.querySelector("#workspace_partnership_user_id").value = event.detail.item.original.id
  this.root.querySelector("#workspace-partnerships-role").focus()
  this.root.querySelector("[type=submit]").removeAttribute("disabled")
}
