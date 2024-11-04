import { atom, useRecoilState } from 'recoil';
import { Schedule } from './types';
// Local storage effect for persistence
const localStorageEffect = (key: string) => ({ setSelf, onSet }: any) => {
    const savedValue = localStorage.getItem(key);
    if (savedValue != null) {
      setSelf(JSON.parse(savedValue));
    }
  
    onSet((newValue: Schedule[], _: any, isReset: boolean) => {
      if (isReset) {
        localStorage.removeItem(key);
      } else {
        localStorage.setItem(key, JSON.stringify(newValue));
      }
    });
  };

export const schedulesState = atom<Schedule[]>({
    key: 'schedulesState',
    default: [],
    effects: [
      localStorageEffect('schedules')
    ]
  });