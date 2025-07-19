import { Observer } from "./observer.js";
import Notification from "../models/Notification.js";

class NotificationObserver extends Observer {
  constructor(userId) {
    super();
    this.userId = userId;
  }

  async update(data) {
    const { title, message } = data;
    await Notification.create({
      user: this.userId,
      title,
      message,
    });
  }
}

export default NotificationObserver;