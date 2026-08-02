import { useState, useRef } from 'react';
import { Upload, Link as LinkIcon, X, Image as ImageIcon, Loader2 } from 'lucide-react';
import { uploadImage } from '../lib/upload';

interface ImageUploadProps {
  value: string;
  onChange: (url: string) => void;
  label?: string;
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

export default function ImageUpload({ value, onChange, label, className = '', size = 'md' }: ImageUploadProps) {
  const [mode, setMode] = useState<'upload' | 'url'>('upload');
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [urlInput, setUrlInput] = useState(value || '');
  const fileRef = useRef<HTMLInputElement>(null);

  const sizeClasses = {
    sm: 'h-24 w-24',
    md: 'h-40 w-full',
    lg: 'h-56 w-full',
  };

  async function handleFile(file: File) {
    if (!file.type.startsWith('image/')) {
      alert('Please select an image file');
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      alert('File size must be under 10MB');
      return;
    }

    setUploading(true);
    try {
      const url = await uploadImage(file);
      onChange(url);
    } catch (err: any) {
      alert(err.message || 'Upload failed');
    }
    setUploading(false);
  }

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) handleFile(file);
  }

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files?.[0];
    if (file) handleFile(file);
  }

  function handleUrlSubmit() {
    if (urlInput.trim()) {
      onChange(urlInput.trim());
    }
  }

  function handleRemove() {
    onChange('');
    setUrlInput('');
    if (fileRef.current) fileRef.current.value = '';
  }

  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      {label && <label className="input-label">{label}</label>}

      {/* Mode Toggle */}
      <div className="flex gap-1 p-0.5 bg-bg-hover rounded-md w-fit">
        <button
          type="button"
          onClick={() => setMode('upload')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded text-xs font-medium transition-colors ${
            mode === 'upload' ? 'bg-bg-card text-text-main shadow-sm' : 'text-text-muted hover:text-text-main'
          }`}
        >
          <Upload size={12} /> Upload
        </button>
        <button
          type="button"
          onClick={() => setMode('url')}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded text-xs font-medium transition-colors ${
            mode === 'url' ? 'bg-bg-card text-text-main shadow-sm' : 'text-text-muted hover:text-text-main'
          }`}
        >
          <LinkIcon size={12} /> Paste URL
        </button>
      </div>

      {/* Preview */}
      {value && (
        <div className="relative inline-block">
          <img
            src={value}
            alt="Preview"
            className={`${size === 'sm' ? 'w-24 h-24' : 'w-full h-40'} object-cover rounded-lg border border-border`}
            onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
          />
          <button
            type="button"
            onClick={handleRemove}
            className="absolute -top-2 -right-2 w-6 h-6 bg-error text-white rounded-full flex items-center justify-center shadow-md hover:bg-red-600 transition-colors"
          >
            <X size={14} />
          </button>
        </div>
      )}

      {/* Upload Mode */}
      {mode === 'upload' && !value && (
        <div
          onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
          onDragLeave={() => setDragOver(false)}
          onDrop={handleDrop}
          onClick={() => fileRef.current?.click()}
          className={`${sizeClasses[size]} flex flex-col items-center justify-center border-2 border-dashed rounded-lg cursor-pointer transition-colors ${
            dragOver ? 'border-primary bg-primary-light' : 'border-border hover:border-primary/50 hover:bg-bg-hover'
          }`}
        >
          <input ref={fileRef} type="file" accept="image/*" onChange={handleFileChange} className="hidden" />
          {uploading ? (
            <div className="flex flex-col items-center gap-2">
              <Loader2 size={24} className="animate-spin text-primary" />
              <span className="text-sm text-text-muted">Uploading...</span>
            </div>
          ) : (
            <div className="flex flex-col items-center gap-2">
              <div className="w-10 h-10 rounded-full bg-bg-hover flex items-center justify-center text-text-muted">
                <ImageIcon size={20} />
              </div>
              <div className="text-center">
                <p className="text-sm font-medium text-text-main">
                  {dragOver ? 'Drop image here' : 'Click to upload or drag & drop'}
                </p>
                <p className="text-xs text-text-muted mt-0.5">PNG, JPG, WebP up to 10MB</p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* URL Mode */}
      {mode === 'url' && !value && (
        <div className="flex gap-2">
          <input
            value={urlInput}
            onChange={(e) => setUrlInput(e.target.value)}
            placeholder="https://example.com/image.jpg"
            className="input-field flex-1"
            onKeyDown={(e) => e.key === 'Enter' && handleUrlSubmit()}
          />
          <button type="button" onClick={handleUrlSubmit} className="btn btn-primary px-4">
            Add
          </button>
        </div>
      )}
    </div>
  );
}
