import { matches, types as T } from "../deps.ts";
const { string, shape, tuple, number } = matches;
const isError = shape({ error: string }).test;
const isErrorCode = shape({ "error-code": tuple(number, string) }).test;
const error = (error: string) => ({ error });
const errorCode = (code: number, error: string) => ({
  "error-code": [code, error] as const,
});
const ok = { result: null };
/** Transform the error into ResultType, and just return the thrown ResultType */
const catchError = (effects: T.Effects) =>
  (e: unknown) => {
    if (isError(e)) return e;
    if (isErrorCode(e)) return e;
    effects.error(`Health check failed: ${e}`);
    return errorCode(61, "Health check has never run");
  };

/** Call to make sure the duration is pass a minimum */
const guardDurationAboveMinimum = (
  input: { duration: number; minimumTime: number },
) =>
  (input.duration <= input.minimumTime)
    ? Promise.reject(errorCode(60, "Starting"))
    : null;

const checkHealthDuration = 5000;

export const healthAlive: T.ExpectedExports.health[""] = async (
  effects,
  duration,
) => {
  await guardDurationAboveMinimum({
    duration,
    minimumTime: checkHealthDuration,
  });
  const response = await effects.fetch("http://vaultwarden.embassy:80/alive");
  if (response.ok) {
    return ok;
  }
  return error("The Vaultwarden UI is unreachable");
};

/** These are the health checks in the manifest */
export const health: T.ExpectedExports.health = {
  /** Checks that the server is running and reachable via cli */
  // deno-lint-ignore require-await
  async alive(effects, duration) {
    return healthAlive(effects, duration).catch(catchError(effects));
  },
};
