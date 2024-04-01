const { SNSHandler } = require('@coaktion/aws')
require('dotenv').config()

const handler = new SNSHandler({
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  },
  region: 'us-east-1',
})

const messages = Array.from({ length: 100 }, (_, i) => ({
  message: {
    content: `Message number ${i + 1}`,
  },
  messageGroupId: 'example'
}))

handler.bulkPublish(process.env.TOPIC_ARN, messages)