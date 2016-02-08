'use strict'
const hashPassword = require('five-bells-shared/utils/hashPassword')
const models = require('../models/db')

module.exports = function * (config) {
  yield setupHoldAccount()
  if (config.get('default_admin')) {
    yield setupAdminAccount(config.get('default_admin').toJS())
  }
}

function * setupHoldAccount () {
  const holdAccount = yield models.Account.findByName('hold')
  if (!holdAccount) {
    yield models.Account.create({name: 'hold', balance: '0'})
  }
}

// adminParams - {user, pass}
function * setupAdminAccount (adminParams) {
  const adminAccount = yield models.Account.findByName(adminParams.user)
  // Update the password if the account already exists.
  if (adminAccount) {
    adminAccount.password_hash = yield hashPassword(adminParams.pass)
    yield adminAccount.save()
  } else {
    yield models.Account.create({
      name: adminParams.user,
      balance: '0',
      password_hash: yield hashPassword(adminParams.pass),
      is_admin: true
    })
  }
}
