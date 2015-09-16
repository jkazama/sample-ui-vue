withdrawalList = new Lib.Vue.List
  el: ".l-withdrawal-list"
  path: "/asset/cio/unprocessedOut/"
  created: ->
    @initialized()

withdrawalCrud = new Lib.Vue.Crud
  el: ".l-withdrawal-crud"
  path: "/asset/cio/withdraw"
  attributes:
    list: withdrawalList
  data:
    item:
      currency: "JPY"
      absAmount: ""
  created: ->
    @initialized()
  methods:
    actionSuccessMessage: -> "依頼を受け付けました"


