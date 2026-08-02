import { Inbox } from 'lucide-react';

interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description: string;
  action?: React.ReactNode;
}

export default function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
      <div className="w-16 h-16 rounded-2xl bg-bg-hover flex items-center justify-center text-text-muted mb-4">
        {icon || <Inbox size={32} />}
      </div>
      <h3 className="text-lg font-semibold text-text-main">{title}</h3>
      <p className="mt-1 text-sm text-text-muted max-w-sm">{description}</p>
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}
