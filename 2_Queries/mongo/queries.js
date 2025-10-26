function truncate(obj, max = 100) {
    return JSON.stringify(obj).substring(0, max) + "..."; 
}

use("phones");

console.log("\n\tFind device of name 'Super ZX' with brand 'Acer'\n");

console.log(truncate(db.devices.findOne({brand_name: "Acer", model_name: "Super ZX"})));

console.log("\n\tFind all devices between 'B' and 'F' alphabetically in brand 'Acer'\n");

console.log(db.devices.find({brand_name: "Acer", model_name: { $gt: "B", $lt: "F"}}, {_id: true, model_name: true}));
