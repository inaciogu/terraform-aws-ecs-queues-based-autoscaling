const { SQSHandler, EvoluttyManager, SQSRouter } = require('@coaktion/evolutty')
require('dotenv').config()

class ExampleHandler extends SQSHandler {
  async handle() {
    return true
  }
}

const manager = new EvoluttyManager([
  {
    handler: ExampleHandler,
    queueName: 'test_scaling_queue',
    routeType: SQSRouter,
    routeParams: {
      region: 'us-east-1',
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      prefixBasedQueues: true
    }
  }
])

manager.start()