import PouchDB from 'pouchdb';
import PouchDBFind from 'pouchdb-find';
PouchDB.plugin(PouchDBFind);

const localDb = new PouchDB('phones');
localDb.createIndex({index: {fields: ['model_name']}});

const remoteDb= `http://${COUCHDB_USER}:${COUCHDB_PASS}@localhost:5984/phones`;

const SyncManager = {
    syncChangeHandler(info) {
        //this.log(info, false);
    },
    syncPauseHandler(err) { // User offline
        this.log(err ?? "Paused", true);
    },
    syncActiveHandler() { // User online
        this.log("Active", false);
    },
    syncDeniedHandler(err) { // Document failed to replicate
        this.log(err, true);
    },
    syncCompleteHandler(info) {
        this.log(info, false);
    },
    syncErrorHandler(err) {
        this.log(err, true);
    },
    log(text, isError) {
        console.log(`Sync Manager [${isError ? 'ERROR' : 'INFO'}]: ${text}`);
    }
}

localDb.sync(remoteDb, { live: true, retry: true })
    .on('change', _ => SyncManager.syncChangeHandler(_))
    .on('paused', _ => SyncManager.syncPauseHandler(_))
    .on('active', () => SyncManager.syncActiveHandler())
    .on('denied', _ => SyncManager.syncDeniedHandler(_))
    .on('complete', _ => SyncManager.syncChangeHandler(_))
    .on('error', _ => SyncManager.syncErrorHandler(_))

const deviceButtonContainerElm = document.getElementById('device-button-container')

const deviceButtonTemplate = '<button class="device-button"></button>';

const DeviceSelectorManager = {
    deviceButtonContainerElm: null,
    previousButtonElm: null,
    nextButtonElm: null,
    deviceButtonElms: [],
    activeDeviceButton: null,
    lastName: null, // Last model name a search was performed from
    isLoading: false,
    init(containerElm, previousButtonElm, nextButtonElm) {
        this.deviceButtonContainerElm = containerElm;
        this.previousButtonElm = previousButtonElm.firstChild;
        this.nextButtonElm = nextButtonElm.firstChild;

        this.previousButtonElm.addEventListener('click', () => this.prevPressedHandler());
        this.nextButtonElm.addEventListener('click', () => this.nextPressedHandler());
    },
    createDeviceButton(id, model_name) {

        let elm = { id: id, model_name: model_name, elm: document.createElement('div') };
        elm.elm.innerHTML = deviceButtonTemplate;
        elm.buttonElm = elm.elm.firstChild;

        elm.buttonElm.value = id;
        elm.buttonElm.innerText = model_name;
        elm.buttonElm.addEventListener('click', (e) => this.deviceButtonPressedHandler(elm));

        this.deviceButtonContainerElm.appendChild(elm.elm);
        this.deviceButtonElms.push(elm);
    },
    select(obj) {
        if(this.activeDeviceButton)
            this.activeDeviceButton.buttonElm.classList.remove('active-device-button');
        this.activeDeviceButton = obj;
        if(obj) {
            this.activeDeviceButton.buttonElm.classList.add('active-device-button');
            localDb.get(this.activeDeviceButton.id).then((doc) => {
                DeviceModelView.load(doc);
            })
        }
    },
    deviceButtonPressedHandler(obj) {
        this.select(obj);
    },
    prevPressedHandler() {
        this.reloadFrom(this.lastName, 10, false);
    },
    nextPressedHandler() {
        this.reloadFrom(this.lastName, 10, true);
    },
    async reloadFrom(from, lim, forward) {
        if(this.isLoading)
            return;

        this.isLoading = true;
        const selector = forward ? {model_name: {$gte: from}} : {model_name: {$lt: from}}
        const sort = forward ? { model_name: 'asc' } : { model_name: 'desc' };

        const result = await localDb.find({selector:selector, sort:[sort], fields: ['_id', 'model_name'], limit: forward ? lim : lim + 1});
        
        if(result.docs.length <= 0) {
            this.isLoading = false;
            return;
        }

        if(!forward)
            result.docs.reverse();

        this.clear();
        result.docs.forEach(doc => {
            DeviceSelectorManager.createDeviceButton(doc._id, doc.model_name);
        });

        this.lastName = result.docs[forward ? result.docs.length - 1 : 0].model_name;

        this.isLoading = false;
    },
    clear() {
        this.deviceButtonElms.forEach(elm => {
            elm.elm.remove();
        });
        this.deviceButtonElms = [];
        this.select(null);
    }
}

const DeviceModelView = {
    activeDoc: null,
    fields: [],
    init(saveButtonElm) {
        saveButtonElm.addEventListener('click', () => this.save());
    },
    load(doc) {
        this.activeDoc = doc;
        this.fields.forEach(field => {
            this.loadField(field);
        });
    },
    registerField(elm) {
        const field = {elm: elm, mapping: elm.dataset.mapping };
        elm.addEventListener('change', () => this.fieldChangeHandler(field));
        this.fields.push(field);
    },
    loadField(field) {
        field.elm.value = this.activeDoc[field.mapping];
    },
    fieldChangeHandler(field) {
        this.activeDoc[field.mapping] = field.elm.value;
    },
    save() {
        if(this.activeDoc)
            localDb.put(this.activeDoc).then(info => localDb.get(info.id).then(doc => this.load(doc)));
    }
}

document.addEventListener('DOMContentLoaded', () => {
    DeviceSelectorManager.init(document.getElementById('device-button-container'), document.getElementById('devices-previous-button'), document.getElementById('devices-next-button'));
    DeviceSelectorManager.reloadFrom('Super ZX', 10, true);

    DeviceModelView.registerField(document.getElementById('device-field-id'));
    DeviceModelView.registerField(document.getElementById('device-field-mname'));
    DeviceModelView.registerField(document.getElementById('device-field-bname'));
    DeviceModelView.init(document.getElementById('device-save-button'))
});
