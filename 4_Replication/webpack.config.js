const HTMLPlugin = require('html-webpack-plugin');

const path = require('path');

require('dotenv').config({path: path.resolve(__dirname, '../.env')});

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
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
        }
    },
    plugins: [
        new HTMLPlugin(({
            template: './src/index.html',
            templateParameters: secrets,
        }))
    ]
};