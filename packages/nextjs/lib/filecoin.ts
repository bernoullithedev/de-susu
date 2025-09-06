import lighthouse from '@lighthouse-web3/sdk';

export async function uploadToFilecoin(metadata: object): Promise<string> {
  const apiKey = process.env.NEXT_PUBLIC_LIGHTHOUSE_API_KEY!;
  const jsonString = JSON.stringify(metadata);
  const response = await lighthouse.uploadText(jsonString, apiKey, 'contribution-metadata.json');
  console.log("Response:",response)
  return response.data.Hash; // CID (e.g., QmY77L7JzF8E7Rio4XboEpXL2kTZnW2oBFdzm6c53g5ay8)
}