export interface StatusRepresentation {
  name: string;
  icon: any;
  color: string;
}
export interface StatusToRepresentationMap {
  [key: string]: StatusRepresentation;
}

export interface StatusIndicatorInterface {
  statusToRep: StatusToRepresentationMap;
  status: string;
  iconSize: "large" | "small";
  defaultStatus: string;
}

export interface LogInterface {
  message: string;
  date: string;
}

export interface Log {
  msg: string;
  timestamp: Date;
}

export interface Schedule {
  id: string;
  name: string;
  datetime: string;
  callback: string;
  executed: boolean;
}