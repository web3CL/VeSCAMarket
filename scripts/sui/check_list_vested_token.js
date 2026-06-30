import { getFullnodeUrl, SuiClient } from "@mysten/sui/client";

const client = new SuiClient({
    url: getFullnodeUrl("testnet"),
});

async function readTable(tableId) {
    try {
        const dynamicFieldPage = await client.getDynamicFields({parentId: tableId});
        const resultData = dynamicFieldPage.data;

        for (const tableRowResult of resultData) {
            const priceTableId = tableRowResult.objectId;
            const priceTable = await client.getObject({
                id: priceTableId,
                options: {showContent: true}
            });

            const priceFields = priceTable.data.content.fields;
            console.log("order nft address =", priceTable.data.objectId);
            console.log("vested token address = ", priceFields.id.id);
            console.log("--------------------------------------------------");
        }
    } catch (error) {
        console.error("An error occurred:", error);
    }
}
// it is the id of table(found in field) not object!
readTable('0xfb1f4a011deddf41d7acbeae944588d8c7d19bffcab5de1662b0f5187638ddd1');