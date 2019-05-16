// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


const dotenv = require('dotenv');
const path = require('path');
//const restify = require('restify');
const express = require('express');
const isInLambda = !!process.env.LAMBDA_TASK_ROOT;

// Import required bot services.
// See https://aka.ms/bot-services to learn more about the different parts of a bot.
const { BotFrameworkAdapter } = require('botbuilder');

// This bot's main dialog.
const { MyBot } = require('./bot');

// Import required bot configuration.
const ENV_FILE = path.join(__dirname, '.env');
dotenv.config({ path: ENV_FILE });

// Create HTTP server
// const server = restify.createServer();
// server.listen(process.env.port || process.env.PORT || 3978, () => {
//     console.log(`\n${ server.name } listening to ${ server.url }`);
//     console.log(`\nGet Bot Framework Emulator: https://aka.ms/botframework-emulator`);
//     console.log(`\nTo talk to your bot, open the emulator select "Open Bot"`);
// });

const app = express();
const port = process.env.port || process.env.PORT || 3978;

if (isInLambda) {
    const serverlessExpress = require('aws-serverless-express');
    const server = serverlessExpress.createServer(app);
    exports.handler = (event, context) => serverlessExpress.proxy(server, event, context)
} else {

    app.listen(port, () => {
        console.log("running inside lambda? ",isInLambda);
        console.log(`\n${ app.name } listening to ${ port }`);
        console.log(`\nGet Bot Framework Emulator: https://aka.ms/botframework-emulator`);
        console.log(`\nTo talk to your bot, open the emulator select "Open Bot"`);
    });
}

// Create adapter.
// See https://aka.ms/about-bot-adapter to learn more about how bots work.
const adapter = new BotFrameworkAdapter({
    appId: process.env.MicrosoftAppId,
    appPassword: process.env.MicrosoftAppPassword
});

// Catch-all for errors.
adapter.onTurnError = async (context, error) => {
    // This check writes out errors to console log .vs. app insights.
    console.error(`\n [onTurnError]: ${ error }`);
    // Send a message to the user
    await context.sendActivity(`Oops. Something went wrong!`);
};

// Create the main dialog.
const myBot = new MyBot();

// Listen for incoming requests.
app.post('/api/messages', (req, res) => {
    adapter.processActivity(req, res, async (context) => {
        // Route to main dialog.
        await myBot.run(context);
    });
});



