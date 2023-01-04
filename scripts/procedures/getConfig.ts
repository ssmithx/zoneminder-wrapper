import { compat, types as T } from "../deps.ts";

export const getConfig: T.ExpectedExports.getConfig = compat.getConfig({
  "admin-token": {
    "type": "string",
    "name": "Admin Token",
    "description":
      "Authentication token for logging into your admin dashboard.",
    "nullable": false,
    "pattern": "[a-zA-Z0-9/=\\-_]+",
    "pattern-description": "Must be a valid base 64 string",
    "copyable": true,
    "masked": true,
    "default": {
      "charset": "a-z,A-Z,0-9,/,=",
      "len": 64,
    },
  },
});
