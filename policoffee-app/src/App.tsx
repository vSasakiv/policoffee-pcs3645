import { Redirect, Route } from "react-router-dom";
import {
  IonApp,
  IonIcon,
  IonLabel,
  IonRouterOutlet,
  IonTabBar,
  IonTabButton,
  IonTabs,
  setupIonicReact,
} from "@ionic/react";
import { IonReactRouter } from "@ionic/react-router";
import { lockOpen, construct, bug } from "ionicons/icons";

import { MqttProvider } from "./contexts/MqttContext";
import UnlockPage from "./pages/UnlockPage";
import ManagePage from "./pages/ManagePage";
import DebugPage from "./pages/DebugPage";

/* Core CSS required for Ionic components to work properly */
import "@ionic/react/css/core.css";

/* Basic CSS for apps built with Ionic */
import "@ionic/react/css/normalize.css";
import "@ionic/react/css/structure.css";
import "@ionic/react/css/typography.css";

/* Optional CSS utils that can be commented out */
import "@ionic/react/css/padding.css";
import "@ionic/react/css/float-elements.css";
import "@ionic/react/css/text-alignment.css";
import "@ionic/react/css/text-transformation.css";
import "@ionic/react/css/flex-utils.css";
import "@ionic/react/css/display.css";

/* Theme variables */
import "./theme/variables.css";

setupIonicReact();

const App: React.FC = () => (
  <IonApp>
    <IonReactRouter>
      <IonTabs>
        <IonRouterOutlet>
          <MqttProvider>
            <Route exact path="/unlock">
              <UnlockPage />
            </Route>
            <Route exact path="/manage">
              <ManagePage />
            </Route>
            <Route exact path="/debug">
              <DebugPage />
            </Route>
            <Route exact path="/">
              <Redirect to="/unlock" />
            </Route>
          </MqttProvider>
        </IonRouterOutlet>
        <IonTabBar slot="bottom">
          <IonTabButton tab="unlock" href="/unlock">
            <IonIcon aria-hidden="true" icon={lockOpen} />
            <IonLabel>Destrancar</IonLabel>
          </IonTabButton>
          <IonTabButton tab="manage" href="/manage">
            <IonIcon aria-hidden="true" icon={construct} />
            <IonLabel>Gerenciar</IonLabel>
          </IonTabButton>
          <IonTabButton tab="debug" href="/debug">
            <IonIcon aria-hidden="true" icon={bug} />
            <IonLabel>Debug</IonLabel>
          </IonTabButton>
        </IonTabBar>
      </IonTabs>
    </IonReactRouter>
  </IonApp>
);

export default App;
