import React from 'react';
import {
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardSubtitle,
  IonList,
  IonItem,
  IonLabel,
  IonText,
  IonIcon,
  IonBadge,
  IonNote
} from '@ionic/react';
import { timeOutline } from 'ionicons/icons';
import { Log } from '../../../types';


interface LogViewerProps {
  logs: Log[];
}

const LogViewer: React.FC<LogViewerProps> = ({ logs }) => {
  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('default', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    }).format(date);
  };

  const getTimeDifference = (timestamp: Date) => {
    const now = new Date();
    const diff = now.getTime() - timestamp.getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) return `${hours}h ago`;
    if (minutes > 0) return `${minutes}m ago`;
    return `${seconds}s ago`;
  };

  if (logs.length === 0) {
    return (
      <IonCard>
        <IonCardContent>
          <IonText color="medium">No logs to display</IonText>
        </IonCardContent>
      </IonCard>
    );
  }

  const reversedLogs = [...logs].reverse();

  return (
    <IonList>
      {reversedLogs.map((log, index) => (
        <IonItem key={index} className="m-[16px]">
          <div>
            <div className="flex items-center justify-between mb-2">
              <IonLabel className="font-medium text-lg">
                {log.msg}
              </IonLabel>
              <IonBadge color="primary" className="ml-2">
                {getTimeDifference(log.timestamp)}
              </IonBadge>
            </div>
            <IonNote className="flex items-center text-sm">
              <IonIcon icon={timeOutline} className="mr-1" />
              {formatDate(log.timestamp)}
            </IonNote>
          </div>
        </IonItem>
      ))}
    </IonList>
  );
};

export default LogViewer;