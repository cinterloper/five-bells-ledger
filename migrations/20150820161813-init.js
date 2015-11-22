'use strict'

module.exports = {
  up: function (queryInterface, Sequelize) {
    queryInterface.createTable('Accounts', {
      id: {
        type: Sequelize.STRING,
        primaryKey: true
      },
      name: Sequelize.STRING,
      balance: Sequelize.DECIMAL(10, 2),
      identity: Sequelize.STRING(1024),
      password: Sequelize.STRING,
      public_key: Sequelize.TEXT,
      is_admin: Sequelize.BOOLEAN,
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    })

    queryInterface.createTable('Transfers', {
      id: {
        type: Sequelize.UUID,
        primaryKey: true
      },
      ledger: Sequelize.STRING(1024),
      debits: Sequelize.TEXT,
      credits: Sequelize.TEXT,
      part_of_payment: Sequelize.STRING(1024),
      state: Sequelize.ENUM('proposed', 'pre_prepared', 'prepared', 'pre_executed', 'executed', 'rejected'),
      execution_condition: Sequelize.TEXT,
      execution_condition_fulfillment: Sequelize.TEXT,
      expires_at: Sequelize.DATE,
      timeline: Sequelize.TEXT,
      proposed_at: Sequelize.DATE,
      pre_prepared_at: Sequelize.DATE,
      prepared_at: Sequelize.DATE,
      pre_executed_at: Sequelize.DATE,
      executed_at: Sequelize.DATE,
      rejected_at: Sequelize.DATE,
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    })

    queryInterface.createTable('Subscriptions', {
      id: {
        type: Sequelize.UUID,
        primaryKey: true
      },
      owner: Sequelize.STRING(1024),
      event: Sequelize.STRING,
      subject: Sequelize.STRING(1024),
      target: Sequelize.STRING(1024),
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    })

    queryInterface.createTable('EntryGroups', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    })

    queryInterface.createTable('Entries', {
      id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true },
      entry_group: Sequelize.UUID,
      transfer_id: Sequelize.UUID,
      account: Sequelize.STRING(1024),
      balance: Sequelize.DECIMAL(10, 2),
      created_at: Sequelize.DATE,
      updated_at: Sequelize.DATE
    })
    queryInterface.addIndex('Entries', ['account', 'entry_group'])
  },

  down: function (queryInterface, Sequelize) {
    queryInterface.dropTable('Accounts')
    queryInterface.dropTable('Transfers')
    queryInterface.dropTable('Subscriptions')
    queryInterface.dropTable('EntryGroups')
    queryInterface.dropTable('Entries')
    queryInterface.removeIndex('Entries', ['account', 'entry_group'])
  }
}
