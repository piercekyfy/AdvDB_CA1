const fs = require('fs');

console.log("Performing First Time Configuration...")

console.log("Deleting Existing...")
try {
    use("phones");
    console.log(db.dropDatabase())
} catch {
    console.log("drop failed")
}

use("phones")

console.log("Creating New...");
console.log(db.createCollection("brands"));

console.log("Uploading Dataset...");
const data = fs.readFileSync("./dataset_phones.json", { encoding: 'utf-8', flag: 'r' });
let dataset = JSON.parse(data);
console.log({"inserted": Object.keys(db.brands.insertMany(dataset.docs).insertedIds).length});

// Additionally, create a view
db.createView(
    "devices",
    "brands",
    [
        {
            $addFields {
                brand: 'brand_name'
            }
        }
    ]
)

console.log("\n----------------------------- DB Setup Complete! -----------------------------\n")
console.log("--------------------------- http://127.0.0.1:27017/ --------------------------\n")