'use server';
import lighthouse from '@lighthouse-web3/sdk';

export async function serverUploadToFilecoin(metadata: object) {
  const apiKey = process.env.LIGHTHOUSE_API_KEY!;
  const jsonString = JSON.stringify(metadata);
  const response = await lighthouse.uploadText(jsonString, apiKey, 'contribution-metadata.json');
  return response.data.Hash;
}