exports.handler = (event, context, callback) => {
  const response = event.Records[0].cf.response;
  response.headers['testheader'] = [{ key: 'testHeader', value: 'testValue' }];
  callback(null, response);
};