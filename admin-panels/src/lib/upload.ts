/**
 * Image Upload Service
 * 
 * Currently stores images as base64 data URLs for development.
 * 
 * TODO: Replace with your cloud storage provider:
 * - AWS S3: Use presigned URLs or AWS SDK
 * - GCP Cloud Storage: Use signed URLs or GCP SDK
 * 
 * Only the final URL is stored in Supabase — never the file itself.
 */

// Configure your upload provider here
type UploadProvider = 'local' | 'aws_s3' | 'gcp';
const UPLOAD_PROVIDER: UploadProvider = 'local';

// AWS S3 Config (fill when ready)
// const AWS_S3_BUCKET = '';
// const AWS_S3_REGION = '';
// const AWS_S3_UPLOAD_ENDPOINT = '';

// GCP Config (fill when ready)
// const GCP_BUCKET = '';
// const GCP_UPLOAD_ENDPOINT = '';

export async function uploadImage(file: File): Promise<string> {
  switch (UPLOAD_PROVIDER) {
    case 'aws_s3':
      return uploadToAWS(file);
    case 'gcp':
      return uploadToGCP(file);
    case 'local':
    default:
      return uploadLocal(file);
  }
}

/**
 * Local upload — converts to base64 data URL for development only.
 * Works without any cloud setup. Replace for production.
 */
async function uploadLocal(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = () => reject(new Error('Failed to read file'));
    reader.readAsDataURL(file);
  });
}

/**
 * AWS S3 Upload
 * Uses a presigned URL from your backend, or direct SDK upload.
 * 
 * Steps to enable:
 * 1. Set up an S3 bucket with CORS enabled
 * 2. Create a backend endpoint that returns a presigned PUT URL
 * 3. Upload the file to that URL
 * 4. Return the public S3 URL
 */
async function uploadToAWS(_file: File): Promise<string> {
  // Example implementation:
  //
  // const { url, key } = await fetch('/api/s3/presign', {
  //   method: 'POST',
  //   body: JSON.stringify({ filename: file.name, contentType: file.type }),
  // }).then(r => r.json());
  //
  // await fetch(url, {
  //   method: 'PUT',
  //   body: file,
  //   headers: { 'Content-Type': file.type },
  // });
  //
  // return `https://${AWS_S3_BUCKET}.s3.${AWS_S3_REGION}.amazonaws.com/${key}`;

  throw new Error('AWS S3 upload not configured. Set up your S3 bucket and update lib/upload.ts');
}

/**
 * Google Cloud Storage Upload
 * Uses a signed URL from your backend.
 * 
 * Steps to enable:
 * 1. Set up a GCS bucket with CORS
 * 2. Create a backend endpoint that returns a signed upload URL
 * 3. Upload the file to that URL
 * 4. Return the public GCS URL
 */
async function uploadToGCP(_file: File): Promise<string> {
  // Example implementation:
  //
  // const { url, publicUrl } = await fetch('/api/gcs/sign', {
  //   method: 'POST',
  //   body: JSON.stringify({ filename: file.name, contentType: file.type }),
  // }).then(r => r.json());
  //
  // await fetch(url, {
  //   method: 'PUT',
  //   body: file,
  //   headers: { 'Content-Type': file.type },
  // });
  //
  // return publicUrl;

  throw new Error('GCP Storage upload not configured. Set up your GCS bucket and update lib/upload.ts');
}
