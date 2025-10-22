import PouchDB from 'pouchdb';

const db = new PouchDB('phones');


function putDevice(device) {
    db.put(device);
}

function displayDevice(device) {
    displayElms.modelName.innerHTML = device.model_name;
}



let displayElms = null;
document.addEventListener('DOMContentLoaded', function() {
    displayElms = {
        modelName: document.getElementById('display-model_name')
    }

    displayDevice({model_name: "Hello World"});
})

