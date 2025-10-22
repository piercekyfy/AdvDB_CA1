const HTMLPlugin = require('html-webpack-plugin');

const path = require('path');

require('dotenv').config();

secrets = {
    COUCHDB_USER: process.env.COUCHDB_USER,
    COUCHDB_PASS: process.env.COUCHDB_PASS
};

module.exports = {
    entry: './src/index.js',
    output: {
        path: path.resolve(__dirname, './dist'),
        filename: 'bundle.js'
    },
    mode: 'development',
    resolve: {
        extensions: ['.js'],
    },
    devServer: {
        static: {
            directory: path.resolve(__dirname, './dist')
        },
        port: 3000,
        hot: true,
        open: true,
        watchFiles: ['src/**/*.html'],
    },
    plugins: [
        new HTMLPlugin(({
            template: './src/index.html',
            templateParameters: secrets,
        }))
    ]
};