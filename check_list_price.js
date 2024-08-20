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
            console.log("price = ", priceFields);
            console.log("--------------------------------------------------");
        }
    } catch (error) {
        console.error("An error occurred:", error);
    }
}
// it is the id of table(found in field) not object!
readTable('0x6b9a2766d65b6fd24b2372b79c1eb340d046112bdde76057da365a7686b20787');