import dayjs from "dayjs";
import localizedFormat from 'dayjs/plugin/localizedFormat'
dayjs.extend(localizedFormat)

export function formatDate(dateString: string) {
		return dayjs(dateString).format('LLL');
	}