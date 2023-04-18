import crypto from 'node:crypto';

export function createNameHash(str: string) {
  return crypto.createHash('shake256', { outputLength: 10 }).update(str).digest('hex');
}
