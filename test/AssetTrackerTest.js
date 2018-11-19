const Asset = artifacts.require('AssetTracker');
const id = "8761924619";
const id2 = "7918702146";

contract('AssetTracker', (accounts) => {
    it('Checks addProduct and getProduct', async function() {
        return Asset.deployed().then(async function(instance) {
            await instance.addProduct(id, "Laptop", "Electronics", 100);
            return instance;
        }).then(async function(instance) {
            const prd = await instance.getProduct(id);
            assert.equal(prd[0], "Laptop", "Name set");
            assert.equal(prd[1], "Electronics", "Category set");
        });
    });

    it('Check addToCart and getCart', async function() {
        return Asset.deployed().then(async function(instance) {
            instance.AddToCart(function(err, res) {
                console.log(res);
            });
            var orderId = await instance.createOrderId();
            orderId = orderId.tx;
            await instance.addToCart(orderId, id, 20);
            await instance.addToCart(orderId, id2, 10);
            await instance.addToCart(orderId, "Test", 5);
            const orders = await instance.getCart(orderId);
            console.log(orders);
            return instance;
        });
    })
});