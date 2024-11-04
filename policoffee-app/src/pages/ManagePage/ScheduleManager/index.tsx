import React, { useEffect, useState } from 'react';
import {  useRecoilState } from 'recoil';
import { schedulesState } from '../../../state';
import {
  IonList, IonItem, IonLabel,
  IonButton,  IonDatetime, IonCard,
  IonCardContent, IonCardHeader, IonCardTitle,
  IonSelect,
  IonSelectOption
} from '@ionic/react';
import { useMqtt } from '../../../contexts/MqttContext';
import { getMqttTopic } from '../../../config';

import { Schedule } from '../../../types';

interface ScheduleManagerProps {
  className?: string;  // Allow custom styling
  onScheduleExecute?: (scheduleName: string) => void;  // Optional callback for schedule execution
}

const ScheduleManager: React.FC<ScheduleManagerProps> = ({
  className = '',
  onScheduleExecute
}) => {
  const mqttTopicInicio = getMqttTopic("inicio");
  const [schedules, setSchedules] = useRecoilState(schedulesState);
  const [newScheduleTime, setNewScheduleTime] = useState('');
  const [modo, setModo] = useState<string | undefined>();
  const {publish} = useMqtt();

  // Execute callback function
  const executeCallback = (scheduleName: string, callbackString: string) => {
    console.log(`Executing schedule: ${scheduleName} with callback: ${callbackString}`);
    publish(mqttTopicInicio, callbackString);
  };

  // Check schedules every 30s
  useEffect(() => {
    const interval = setInterval(() => {
      const now = new Date();

      setSchedules(currentSchedules =>
        currentSchedules.map(schedule => {
          if (!schedule.executed && new Date(schedule.datetime) <= now) {
            executeCallback(schedule.name, schedule.callback);
            return { ...schedule, executed: true };
          }
          return schedule;
        })
      );
    }, 30000);

    // Initial check on component mount
    const now = new Date();
    setSchedules(currentSchedules =>
      currentSchedules.map(schedule => {
        if (!schedule.executed && new Date(schedule.datetime) <= now) {
          executeCallback(schedule.name, schedule.callback);
          return { ...schedule, executed: true };
        }
        return schedule;
      })
    );

    return () => clearInterval(interval);
  }, [setSchedules, onScheduleExecute]);

  const addSchedule = () => {
    if (!newScheduleTime) return;
    if (modo === undefined) {
      alert("Selecione um modo!")
      return;
    }

    const newSchedule: Schedule = {
      id: Date.now().toString(),
      name: modo === 'M' ? "Médio" : "Grande",
      datetime: new Date(newScheduleTime).toISOString(),
      callback: modo,
      executed: false
    };

    setSchedules([...schedules, newSchedule]);
    setNewScheduleTime('');
    setModo(undefined);
  };

  const removeSchedule = (id: string) => {
    setSchedules(schedules.filter(schedule => schedule.id !== id));
  };

  const clearExecutedSchedules = () => {
    setSchedules(schedules.filter(schedule => !schedule.executed));
  };

  const formatDateTime = (datetime: string) => {
    return new Date(datetime).toLocaleString();
  };

  return (
    <div className={className}>
      <IonCard>
        <IonCardHeader>
          <IonCardTitle>Criar Novo Agendamento</IonCardTitle>
        </IonCardHeader>
        <IonCardContent>
          <IonItem>
            <IonItem>
              <IonSelect  value={modo} onIonChange={e => setModo(e.detail.value)} label="Modo de Preparo" placeholder="Modo de Preparo">
                <IonSelectOption value="M">Médio</IonSelectOption>
                <IonSelectOption value="G">Grande</IonSelectOption>
              </IonSelect>
            </IonItem>

          </IonItem>
          <IonItem>
            <IonLabel position="stacked">Horário do Agendamento</IonLabel>
            <IonDatetime
              value={newScheduleTime}
              onIonChange={e => setNewScheduleTime(typeof e.detail.value === "string" ? e.detail.value : (e.detail.value) ? e.detail.value[0] : '')}
            />
          </IonItem>

          <IonButton
            expand="block"
            onClick={addSchedule}
            disabled={!modo || !newScheduleTime}
          >
            Adicionar
          </IonButton>
        </IonCardContent>
      </IonCard>

      <IonCard>
        <IonCardHeader>
          <IonCardTitle>Agendamentos Feitos</IonCardTitle>
        </IonCardHeader>
        <IonCardContent>
          <IonList>
            {schedules.map(schedule => (
              <IonItem key={schedule.id}>
                <IonLabel>
                  <h2>{schedule.name}</h2>
                  <p>{formatDateTime(schedule.datetime)}</p>
                  <p>{schedule.executed ? 'Executado' : 'Pendente'}</p>
                </IonLabel>
                <IonButton
                  slot="end"
                  color="danger"
                  onClick={() => removeSchedule(schedule.id)}
                >
                  Remover
                </IonButton>
              </IonItem>
            ))}
          </IonList>

          {schedules.some(s => s.executed) && (
            <IonButton
              expand="block"
              color="medium"
              onClick={clearExecutedSchedules}
            >
              Limpar agendamentos executados
            </IonButton>
          )}
        </IonCardContent>
      </IonCard>
    </div>
  );
};

export default ScheduleManager;