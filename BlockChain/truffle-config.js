module.exports = {
  networks: {
    development: {
    host: "127.0.0.1",     // Localhost (default: none)
    port: 7545,            // Standard Ethereum port (default: none)
    network_id: "1",       // Any network (default: none)
    from : "0x0c63e5807D80dCF00389baAE8DCa9f5AC4a4d937",
    },
  },

  mocha: {
  },

  compilers: {
    solc: {}
  }
}
