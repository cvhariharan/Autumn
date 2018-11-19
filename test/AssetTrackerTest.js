const Asset = artifacts.require('AssetTracker');
const id = "8761924619";
const id2 = "7918702146";

const jsonrpc = '2.0'


const send = (method, params = []) =>
  web3.currentProvider.send({ id, jsonrpc, method, params })

const timeTravel = async seconds => {
  await send('evm_increaseTime', [seconds])
  await send('evm_mine')
}

contract('AssetTracker', (accounts) => {
    it('Checks addProduct and getProduct', async function() {
        return Asset.deployed().then(async function(instance) {
            await instance.addProduct(id, "Laptop", "Electronics", 40);
            await instance.addProduct(id2, "Mobile", "Electronics", 80);
            return instance;
        }).then(async function(instance) {
            const prd = await instance.getProduct(id);
            assert.equal(prd[0], "Laptop", "Name set");
            assert.equal(prd[1], "Electronics", "Category set");
            const tokens = await instance.getTokens(id);
            console.log(tokens)
        });
    });

    it('Check addToCart and getCart', async function() {
        return Asset.deployed().then(async function(instance) {
            instance.AddToCart(function(err, res) {
                console.log(res);
            });
            await instance.createOrderId();
            var orderId = await instance.getOrderId();
            console.log(orderId.toNumber());
            await instance.addToCart(orderId, id, 2);
            await instance.addToCart(orderId, id2, 10);
            const orders = await instance.getCart(orderId);

            //New order
            await instance.createOrderId();
            var orderId1 = await instance.getOrderId();
            console.log(orderId1.toNumber());
            await instance.addToCart(orderId1, id, 3);
            await instance.addToCart(orderId1, id2, 10);
            const orders1 = await instance.getCart(orderId1);

            console.log(orders1);
            
        });
    })

    it('Checks transferProduct', async function() {
        return Asset.deployed().then(async function(instance) {
            await instance.transferProduct(accounts[2], id, 2, {from: accounts[0]});
            const tokens = await instance.getUserTokens(accounts[2]);
            console.log(tokens);
        })
    });
});